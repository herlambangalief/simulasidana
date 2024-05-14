class SimulasiController < ApplicationController
require 'date'
require 'active_support/core_ext/integer/time'


    def index
        @data_simulasi = Dana.all
        @admin = 5000;
        @target = session[:target_dana] || 0
        @saldo = session[:saldo] || 0
        @periode = session[:periode] || 0
        @setoran = session[:setoran] || 0
        @bunga = session[:bunga] || 0.75
        @tanggal_pembukaan = session[:tanggal_pembukaan] || Date.today
    end

    def create
        Dana.delete_all
        session[:target_dana] = params[:target_dana]
        session[:saldo] = params[:saldo]
        session[:periode] = params[:periode]
        session[:setoran] = params[:setoran]
        session[:bunga] = params[:bunga]
        session[:tanggal_pembukaan] = params[:tanggal_pembukaan]
        target = params[:target_dana].to_f
        saldo = params[:saldo].to_f
        periode = params[:periode].to_i
        setoran = params[:setoran].to_f
        bunga = params[:bunga].to_f / 100 / 12
        tanggal_pembukaan = Date.parse(params[:tanggal_pembukaan])
        admin = 5000
        bulan = 0
        data_simulasi = []
        perulangan = 0
        while saldo < target 
            setoran_bulan_ini = bulan == 0 ? 0 : setoran
            bunga_bulanan = bunga * (saldo + setoran_bulan_ini)
            pajak_bunga = 0.2 * bunga_bulanan
            saldo_sebelumnya = saldo
            saldo += setoran_bulan_ini + bunga_bulanan - pajak_bunga - admin
            if saldo < 0
                redirect_to root_path, notice: 'Perhitungan menghasilkan data dibawah 0, menghentikan proses';
                return
            end
            perulangan += 1
            if perulangan > 80
                data_simulasi.each do |data|
                    Dana.create(data)
                end
                redirect_to root_path, notice: 'Perhitungan melebihi kapasitas';
                return
            end
            bulan += 1
            tanggal_sekarang = tanggal_pembukaan + bulan.months
            kondisi = if bulan <= periode && saldo >= target
                        'target_success'
                      elsif bulan < periode
                        'before_period'
                      elsif bulan == periode 
                        'time_period'
                      elsif bulan > periode && saldo >= target
                        'target_fail'
                      else
                        'after_period'
                      end
            data_simulasi << {
                tanggal: tanggal_sekarang, 
                saldo_sebelumnya: saldo_sebelumnya,
                setoran: setoran_bulan_ini, 
                bunga: bunga_bulanan, 
                pajak_bunga: pajak_bunga, 
                saldo: saldo,
                kondisi: kondisi
            }
        end

        data_simulasi.each do |data|
        Dana.create(data)
        end
        redirect_to action: :index
    end

    def reset
        Dana.delete_all
        reset_session
        redirect_to action: :index
    end

    private
    def sim_params
        params.permit(:target_dana, :periode, :saldo, :setoran, :bunga, :tanggal_pembukaan)
    end
end
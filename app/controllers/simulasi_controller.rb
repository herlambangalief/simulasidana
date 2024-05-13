class SimulasiController < ApplicationController
require 'date'
require 'active_support/core_ext/integer/time'


    def index
        @data_simulasi = session[:simulasi]
        session[:simulasi] = nil
        @admin = 5000;
    end

    

    def create
        target = params[:target_dana].to_f
        saldo = params[:saldo].to_f
        periode = params[:periode].to_i
        setoran = params[:setoran].to_f
        bunga = params[:bunga].to_f / 100 / 12
        admin = 5000
        tanggal_pembukaan = Date.parse(params[:tanggal_pembukaan])
        bulan = 0
        data_simulasi = []

        max_iterations = 12  # Batasi jumlah iterasi untuk menghindari overflow
        while saldo < target && bulan < periode && bulan < max_iterations
            setoran_bulan_ini = bulan == 0 ? 0 : setoran
            bunga_bulanan = bunga * (saldo + setoran_bulan_ini)
            pajak_bunga = 0.2 * bunga_bulanan
            saldo_sebelumnya = saldo
            saldo += setoran_bulan_ini + bunga_bulanan - pajak_bunga - admin
            bulan += 1
            tanggal_sekarang = tanggal_pembukaan + bulan.months
            data_simulasi << {
                tanggal: tanggal_sekarang, 
                saldo_sebelumnya: saldo_sebelumnya,
                setoran: setoran_bulan_ini, 
                bunga: bunga_bulanan, 
                pajak_bunga: pajak_bunga, 
                saldo: saldo
            }
        end

        session[:simulasi] = data_simulasi
        redirect_to action: :index
    end

    private
    def sim_params
        params.permit(:target_dana, :periode, :saldo, :setoran, :bunga, :tanggal_pembukaan)
    end
end
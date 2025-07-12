--ＣＮｏ.９ 天蓋妖星カオス・ダイソン・スフィア (Anime)
--Number C9: Chaos Dyson Sphere (Anime)
Duel.LoadCardScript("c32559361.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon: 3 Level 10 monsters
	Xyz.AddProcedure(c,nil,10,3)
	--Rank Up Check
	aux.EnableCheckRankUp(c,nil,nil,1992816)
	--Cannot be destroyed by battle except with "Number" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(aux.NOT(aux.TargetBoolFunction(Card.IsSetCard,SET_NUMBER)))
	c:RegisterEffect(e1)
	--Inflict 500 damage to your opponent for each Xyz Material attached to this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	--Inflict 800 damage to your opponent for each Xyz Material detached to activate this effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(Cost.DetachFromSelf(s.damcost,s.damcost,function(e,og) e:SetLabel(#og) end))
	e3:SetTarget(s.damtg2)
	e3:SetOperation(s.damop2)
	c:RegisterEffect(e3)
	--Attach an opponent's monster this card battles to it as material
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLED)
	e4:SetTarget(s.attachtg)
	e4:SetOperation(s.attachop)
	--While this card has Xyz Material, your opponent cannot target monsters for attacks, except this one
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,LOCATION_MZONE)
	e5:SetCondition(function(e) return e:GetHandler():GetOverlayCount()>0 end)
	e5:SetValue(function(e,c) return c~=e:GetHandler() end)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_RANKUP_EFFECT)
	e6:SetLabelObject(e4)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetLabelObject(e5)
	c:RegisterEffect(e7)
end
s.listed_series={SET_NUMBER}
s.listed_names={1992816} --"Number 9: Dyson Sphere"
s.xyz_number=9
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetOverlayCount()
	if chk==0 then return ct>0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*500)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=e:GetHandler():GetOverlayCount()
	Duel.Damage(p,ct*500,REASON_EFFECT)
end
function s.damcost(e,tp)
	return e:GetHandler():GetOverlayCount()
end
function s.damtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=e:GetLabel()
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*800)
end
function s.damop2(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=e:GetLabel()
	Duel.Damage(p,ct*800,REASON_EFFECT)
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if chk==0 then return tc and c:IsType(TYPE_XYZ) and not tc:IsType(TYPE_TOKEN) and tc:IsAbleToChangeControler()
		and not c:IsStatus(STATUS_BATTLE_DESTROYED) and c:IsOnField() end
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToBattle() and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(c,tc,true)
	end
end

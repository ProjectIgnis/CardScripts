--Ｎｏ．６ 先史遺産アトランタル
--Number 6: Chronomaly Atlandis
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 6 monsters
	Xyz.AddProcedure(c,nil,6,2)
	--Equip 1 "Number" monster from your GY to this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e) return e:GetHandler():IsXyzSummoned() end)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	aux.AddEREquipLimit(c,nil,function(ec,c,tp) return ec:IsSetCard(SET_NUMBER) and ec:IsControler(tp) end,function(c,e,tp,tc) c:EquipByEffectAndLimitRegister(e,tp,tc,id) end,e1)
	--This card gains ATK equal to half the ATK of that equipped monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(function(e,c) return c:GetEquipGroup():Match(Card.HasFlagEffect,nil,id):GetSum(Card.GetAttack)/2 end)
	c:RegisterEffect(e2)
	--Halve your opponent's Life Points
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(Cost.AND(Cost.Detach(1),s.halvelpcost))
	e3:SetOperation(function(e,tp) local opp=1-tp Duel.SetLP(opp,Duel.GetLP(opp)/2) end)
	c:RegisterEffect(e3)
end
s.xyz_number=6
s.listed_series={SET_NUMBER}
function s.eqfilter(c,tp)
	return c:IsSetCard(SET_NUMBER) and c:IsMonster() and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.eqfilter(chkc,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,tp,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) then
		c:EquipByEffectAndLimitRegister(e,tp,tc,id)
	end
end
function s.halvelpcostfilter(c,tp)
	return c:HasFlagEffect(id) and c:IsControler(tp) and c:IsAbleToGraveAsCost()
end
function s.halvelpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local eqg=c:GetEquipGroup():Match(s.halvelpcostfilter,nil,tp)
	if chk==0 then return Duel.IsPhase(PHASE_MAIN1) and #eqg>0 end
	local g=nil
	if #eqg==1 then
		g=eqg
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		g=eqg:Select(tp,1,1,nil)
	end
	Duel.SendtoGrave(g,REASON_COST)
	--You cannot conduct your Battle Phase the turn you activate this effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
--No.9 天蓋星ダイソン・スフィア (Anime)
--Number 9: Dyson Sphere (Anime)
Duel.LoadCardScript("c1992816.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon procedure
	Xyz.AddProcedure(c,nil,9,2)
	c:EnableReviveLimit()
	--Negate attack if this card has Xyz materials
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_BATTLE_PHASE)
	e1:SetCondition(s.atkcon)
	e1:SetCost(s.atkcost)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--Attach 2 monsters from your GY if this card is attacked while it has no Xyz materials
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(function(e) return e:GetHandler():GetOverlayCount()==0 end)
	e2:SetTarget(s.oltg)
	e2:SetOperation(s.olop)
	c:RegisterEffect(e2)
	--Direct Attack 
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.dacon)
	e3:SetCost(Cost.Detach(1))
	e3:SetOperation(s.daop)
	c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
	--Cannot be destroyed by battle, except by "Number" monsters
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetValue(aux.NOT(aux.TargetBoolFunction(Card.IsSetCard,SET_NUMBER)))
	c:RegisterEffect(e4)
end
s.xyz_number=9
s.listed_series={SET_NUMBER}
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler()==Duel.GetAttackTarget() and e:GetHandler():GetOverlayCount()>0
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(id)==0 end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE,0,1)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateAttack()
end
function s.oltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc:IsMonster() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsMonster,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,Card.IsMonster,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,2,0,0)
end
function s.olop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local g=Duel.GetTargetCards(e)
		if #g>0 then
			Duel.Overlay(c,g)
		end
	end
end
function s.dafilter(c,atk)
	return c:IsFaceup() and c:GetAttack()>atk
end
function s.dacon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 
	and Duel.IsExistingMatchingCard(s.dafilter,tp,0,LOCATION_MZONE,1,nil,e:GetHandler():GetAttack())
end
function s.daop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e)
		and Duel.IsExistingMatchingCard(s.dafilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack()) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e1)
	end
end
--メルフィータイム
--Melffy Playhouse
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Return cards your opponent controls to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP|TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCondition(aux.StatChangeDamageStepCondition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
function s.beastxyzfilter(c)
	return c:IsRace(RACE_BEAST) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	local xyzg=Duel.GetMatchingGroup(s.beastxyzfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then
		local cost_chk=e:GetLabel()==100
		e:SetLabel(0)
		return cost_chk and Duel.CheckRemoveOverlayCard(tp,0,0,1,REASON_COST,xyzg)
			and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil)
	end
	local xyz_max_ct=xyzg:GetSum(Card.GetOverlayCount)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
	local detach_ct=Duel.RemoveOverlayCard(tp,0,0,1,xyz_max_ct,REASON_COST,xyzg)
	e:SetLabel(detach_ct)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,detach_ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
	local atkg=Duel.GetMatchingGroup(s.beastxyzfilter,tp,LOCATION_MZONE,0,nil)
	if #atkg==0 then return end
	local c=e:GetHandler()
	local atk=e:GetLabel()*500
	for tc in atkg:Iter() do
		--They gain 500 ATK for each material detached to activate this card, until the end of this turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end
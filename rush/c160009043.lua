-- メテオ・チャージ
-- Meteor Charge
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Grant piercing damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function() return Duel.IsAbleToEnterBP() end)
	e1:SetTarget(s.pctg)
	e1:SetOperation(s.pcop)
	c:RegisterEffect(e1)
end
function s.pcfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_GALAXY) and c:CanGetPiercingRush()
end
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,s.pcfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if not tc then return end
	Duel.HintSelection(tc,true)
	tc:AddPiercing(RESETS_STANDARD_PHASE_END,e:GetHandler())
	if not tc:IsType(TYPE_NORMAL) then return end
	local pg=Duel.GetMatchingGroup(Card.IsCanChangePositionRush,tp,0,LOCATION_MZONE,nil)
	if #pg==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=pg:Select(tp,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g,true)
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
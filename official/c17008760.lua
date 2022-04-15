--原質の円環炉
--Materiactor Annulus
--Logical Nonsense

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Detach 1 Xyz material from your monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(function(_,tp,_,_,_,_,_,_,chk) if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT) end end)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
	--Detach 1 Xyz material from your monster
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_EFFECT) then return end
	--Set the detached card
	local rc=Duel.GetOperatedGroup():GetFirst()
	if not (rc:IsLocation(LOCATION_GRAVE) and rc:IsControler(tp)) then return end
	if rc:IsMonster() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and rc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		Duel.SpecialSummon(rc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		Duel.ConfirmCards(1-tp,rc)
	elseif rc:IsSSetable() and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		Duel.SSet(tp,rc)
	end
end
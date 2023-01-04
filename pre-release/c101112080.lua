--初買い
--First Purchase of the Year
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>=5 end
end
local declare_lp_table={}
for i=1,30 do
	declare_lp_table[i]=i*100
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.ConfirmDecktop(1-tp,5)
	local g=Duel.GetDecktopGroup(1-tp,5)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sc=g:Select(tp,1,1,nil):GetFirst()
	Duel.ConfirmCards(1-tp,sc)
	local ac=Duel.AnnounceNumber(tp,declare_lp_table)
	if sc:IsAbleToHand() and Duel.SelectYesNo(1-tp,aux.Stringid(id,1))
		and Duel.Recover(1-tp,ac,REASON_EFFECT)>0 then
		Duel.SetLP(tp,Duel.GetLP(tp)-ac)
		Duel.DisableShuffleCheck(true)
		Duel.SendtoHand(sc,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sc)
		Duel.ShuffleHand(tp)
	end
end
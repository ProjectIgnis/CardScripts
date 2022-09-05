--フルアーマー・グラビテーション
--Full Armor Gravitation
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetDecktopGroup(tp,10)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummon(tp)
		and g:FilterCount(Card.IsAbleToRemove,nil)==10 and not Duel.IsPlayerAffectedByEffect(tp,CARD_EHERO_BLAZEMAN) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spfilter(c,e,tp,seq)
	return c:IsSequence(seq) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsType(TYPE_ARMOR)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(tp,10)
	if #g==0 then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.DisableShuffleCheck()
	Duel.ConfirmDecktop(tp,10)
	if ft==0 then return Duel.Remove(g,POS_FACEUP,REASON_EFFECT) end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local seq=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)-1
	local tc=nil
	for i=1,#g do
		tc=g:Filter(s.spfilter,nil,e,tp,seq):GetFirst()
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			g:RemoveCard(tc)
			ft=ft-1
			if ft==0 then break end
		end
		seq=seq-1
	end
	if Duel.SpecialSummonComplete()>0 then Duel.BreakEffect() end
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
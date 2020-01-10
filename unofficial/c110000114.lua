--Full Armor Gravitation
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
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
		and g:FilterCount(Card.IsAbleToRemove,nil)==10 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_DECK)
end
function s.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsType(0x10000000)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(tp,10)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if g:FilterCount(Card.IsAbleToRemove,nil)~=10 then return end
	Duel.DisableShuffleCheck()
	Duel.ConfirmDecktop(tp,10)
	if not Duel.IsPlayerCanSpecialSummon(tp) or ft<=0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		return
	end
	local ct=g:FilterCount(s.filter,nil,e,tp)
	if ct>0 and ft>=ct then
		local g2=g:Filter(s.filter,nil,e,tp)
		Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
		g:Sub(g2)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		return
	end
	ct=1
	local g1=Duel.GetDecktopGroup(tp,ct)
	local g2=Duel.GetDecktopGroup(tp,ct+1)
	g2:Sub(g1)
	if g1:GetFirst():IsType(0x10000000) and g1:GetFirst():IsCanBeSpecialSummoned(e,0,tp,false,false) and ft>0 then
		Duel.SpecialSummonStep(g1:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
		g:RemoveCard(g1:GetFirst())
		ft=ft-1
	end
	local tc=g2:GetFirst()
	if tc:IsType(0x10000000) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and ft>0 then
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		g:RemoveCard(tc)
		ft=ft-1
	end
	while ct+1<10 do
		ct=ct+1
		g1=Duel.GetDecktopGroup(tp,ct)
		g2=Duel.GetDecktopGroup(tp,ct+1)
		g2:Sub(g1)
		tc=g2:GetFirst()
		if tc:IsType(0x10000000) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and ft>0 then
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			g:RemoveCard(tc)
			ft=ft-1
		end
	end
	Duel.SpecialSummonComplete()
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end

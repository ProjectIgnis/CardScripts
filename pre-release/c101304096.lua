--JP name
--Anti-GMX Final Experiment
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate only if you control a "GMX" monster
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_GMX),tp,LOCATION_MZONE,0,1,nil) end)
	c:RegisterEffect(e0)
	--Once per turn, when your opponent activates a monster effect on the field (except during the Damage Step): You can excavate the top 5 cards of your Deck, then if you excavated a "GMX" card(s), negate that activated effect, also place all the excavated cards on the top or bottom of the Deck in any order
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.excavcon)
	e1:SetTarget(s.excavtg)
	e1:SetOperation(s.excavop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_GMX}
function s.excavcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsMonsterEffect() and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE
end
function s.excavtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,eg,1,tp,0)
end
function s.excavop(e,tp,eg,ep,ev,re,r,rp)
	local decktop5=Duel.GetDecktopGroup(tp,5)
	if #decktop5==0 then return end
	Duel.ConfirmDecktop(tp,5)
	Duel.RaiseEvent(decktop5,EVENT_CUSTOM+101304092,e,REASON_EFFECT,tp,tp,#decktop5)
	if decktop5:IsExists(Card.IsSetCard,1,nil,SET_GMX) then
		Duel.BreakEffect()
		Duel.NegateEffect(ev)
	end
	local op=0
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>5 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	end
	if op==0 then
		Duel.SortDecktop(tp,tp,#decktop5)
	else
		Duel.MoveToDeckBottom(decktop5,tp)
		Duel.SortDeckbottom(tp,tp,#decktop5)
	end
end
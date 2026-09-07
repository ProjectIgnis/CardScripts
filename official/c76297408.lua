--魂粉砕
--Soul Demolition
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Each player banished a card from their GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(s.rmcon)
	e2:SetCost(Cost.PayLP(500))
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_FIEND),tp,LOCATION_MZONE,0,1,nil)
end
function s.rfilter(c)
	return c:IsMonster() and c:IsAbleToRemove() and aux.SpElimFilter(c)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.rfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,nil)
		and Duel.IsExistingTarget(s.rfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil) end
	local sel_player=Duel.GetTurnPlayer()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectTarget(sel_player,s.rfilter,sel_player,0,LOCATION_MZONE|LOCATION_GRAVE,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
	local g2=Duel.SelectTarget(1-sel_player,s.rfilter,1-sel_player,0,LOCATION_MZONE|LOCATION_GRAVE,1,1,nil)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,#g1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	g1,g2=g:Split(Card.IsControler,nil,tp)
	if #g1>0 then
		Duel.Remove(g1,POS_FACEUP,REASON_EFFECT,PLAYER_NONE,1-tp)
	end
	if #g2>0 then
		Duel.Remove(g2,POS_FACEUP,REASON_EFFECT,PLAYER_NONE,tp)
	end
end
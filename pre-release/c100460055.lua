--ゴーストリック・フリーズ
--Ghostrick Freeze
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMING_STANDBY_PHASE)
	c:RegisterEffect(e0)
	--After a Spell/Trap(s) becomes Set on your opponent's field while you do not control any face-up cards other than "Ghostrick" cards, it cannot be activated until the end of the next turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SSET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return eg:IsExists(aux.AND(Card.IsControler,Card.IsOnField),1,nil,1-tp) and not Duel.IsExistingMatchingCard(aux.FaceupFilter(aux.NOT(Card.IsSetCard),SET_GHOSTRICK),tp,LOCATION_ONFIELD,0,1,nil)
	end)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local g=eg:Filter(aux.AND(Card.IsControler,Card.IsOnField),nil,1-tp)
		for sc in g:Iter() do
			--It cannot be activated until the end of the next turn
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetReset(RESETS_STANDARD_PHASE_END,2)
			sc:RegisterEffect(e1)
		end
	end)
	c:RegisterEffect(e1)
	--Once per turn: You can shuffle up to 5 "Ghostrick" cards from your GY and/or banishment into the Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
	--If this card in your possession is sent to your GY by an opponent's card: You can change all monsters your opponent controls to face-down Defense Position. The monsters that were, cannot change their battle positions
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_SET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.poscon)
	e3:SetTarget(s.postg)
	e3:SetOperation(s.posop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_GHOSTRICK}
function s.tdfilter(c)
	return c:IsSetCard(SET_GHOSTRICK) and c:IsFaceup() and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,5,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanTurnSet,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,tp,POS_FACEDOWN_DEFENSE)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,0,LOCATION_MZONE,nil)
	if #g>0 and Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)>0 then
		local c=e:GetHandler()
		local og=Duel.GetOperatedGroup()
		for fdc in og:Iter() do
			--The monsters that were, cannot change their battle positions
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3313)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			fdc:RegisterEffect(e1)
		end
	end
end
--トラミッド・ダンサー
--Triamid Dancer
local s,id=GetID()
function s.initial_effect(c)
	--Shuffle 1 "Triamid" card into the Deck and increase the ATK/DEF of Rock monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	--Activate 1 "Triamid" Field Spell from the Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(function(_,tp) return Duel.IsTurnPlayer(1-tp) end)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_series={SET_TRIAMID}
function s.tdfilter(c)
	return c:IsSetCard(SET_TRIAMID) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_ROCK),tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK|LOCATION_EXTRA) then
		local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsRace,RACE_ROCK),tp,LOCATION_MZONE,0,nil)
		for sc in g:Iter() do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			sc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			sc:RegisterEffect(e2)
		end
	end
end
function s.filter(c,tp,code)
	return c:IsFieldSpell() and c:IsSetCard(SET_TRIAMID) and c:GetActivateEffect():IsActivatable(tp,true, true) and not c:IsCode(code)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	if chkc then return false end
	if chk==0 then return tc and tc:IsFaceup() and tc:IsSetCard(SET_TRIAMID) and tc:IsAbleToGrave() and tc:IsCanBeEffectTarget(e)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,tp,tc:GetCode()) end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tc,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local fc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,tp,tc:GetCode()):GetFirst()
		Duel.ActivateFieldSpell(fc,e,tp,eg,ep,ev,re,r,rp)
	end
end
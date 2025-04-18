--烙印喪失
--Branded Loss
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_ALBAZ}
function s.tdfilter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsAbleToDeck()
		and ((c:IsControler(tp) and c:IsFaceup() and c:IsType(TYPE_FUSION))
		or (c:IsControler(1-tp) and c:IsSpecialSummoned() and c:IsSummonLocation(LOCATION_EXTRA)))
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsControler,nil,tp)==1
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local rg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e,tp)
	if chk==0 then return aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,1,tp,HINTMSG_TODECK)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,2,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_EITHER,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
	--During the End Phase of this turn, each player can Special Summon 1 Fusion Monster that mentions "Fallen of Albaz" as material from their own Extra Deck
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.spfilter(c,e)
	local tp=c:GetControler()
	return c:IsType(TYPE_FUSION) and c:ListsCodeAsMaterial(CARD_ALBAZ) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.spfilter,0,LOCATION_EXTRA,LOCATION_EXTRA,1,nil,e)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.spfilter,0,LOCATION_EXTRA,LOCATION_EXTRA,nil,e)
	local turn_p=Duel.GetTurnPlayer()
	local step=turn_p==0 and 1 or -1
	for p=turn_p,1-turn_p,step do
		if g:IsExists(Card.IsControler,1,nil,p) and Duel.SelectYesNo(p,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)
			local sc=g:Filter(Card.IsControler,nil,p):Select(p,1,1,nil):GetFirst()
			if sc then
				Duel.SpecialSummonStep(sc,0,p,p,false,false,POS_FACEUP)
			end
		end
	end
	Duel.SpecialSummonComplete()
end
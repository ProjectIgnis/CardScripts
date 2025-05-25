--巳剣之神鏡
--Mitsurugi Mirror
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Ritual Summon any Reptile Ritual Monster from your hand or GY
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=function(c) return c:IsRace(RACE_REPTILE) end,matfilter=function(c) return c:IsRace(RACE_REPTILE) end,location=LOCATION_HAND|LOCATION_GRAVE})
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	--Shuffle this card into the Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_RELEASE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.tdcon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
s.listed_names={19899073,55397172,13332685}
--"Ame no Murakumo no Mitsurugi", "Futsu no Mitama no Mitsurugi", "Ame no Habakiri no Mitsurugi"
function s.tdconfilter(c,tp)
	return c:IsPreviousCodeOnField(19899073,55397172,13332685) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.tdconfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,tp,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.HintSelection(c)
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
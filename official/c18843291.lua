--ライトロード・アテナ ミネルバ
--Minerva, the Athenian Lightsworn
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon Procedure
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--"Lightsworn" monsters you control cannot be banished by card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_REMOVE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,1)
	e1:SetTarget(s.rmlimit)
	c:RegisterEffect(e1)
	--Send "Lightsworn" monsters with different Types from your Deck to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(function(e) return e:GetHandler():IsSynchroSummoned() end)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	--Register the number of "Lightsworn" materials used for its summon
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_SINGLE)
	e2a:SetCode(EFFECT_MATERIAL_CHECK)
	e2a:SetValue(s.valcheck)
	e2a:SetLabelObject(e2)
	c:RegisterEffect(e2a)
	--Send cards from the top of your Deck to the GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(s.toptgcost)
	e3:SetTarget(s.toptgtg)
	e3:SetOperation(function(e,tp) Duel.DiscardDeck(tp,e:GetLabel(),REASON_EFFECT) end)
	c:RegisterEffect(e3)
end
s.listed_series={SET_LIGHTSWORN}
function s.rmlimit(e,c,tp,r)
	return c:IsSetCard(SET_LIGHTSWORN) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup()
		and c:IsControler(e:GetHandlerPlayer()) and not c:IsImmuneToEffect(e) and r&REASON_EFFECT>0
end
function s.tgfilter(c)
	return c:IsSetCard(SET_LIGHTSWORN) and c:IsMonster() and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabel()>0 and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	if #g==0 then return end
	local ct=math.min(e:GetLabel(),#g)
	local tg=aux.SelectUnselectGroup(g,e,tp,1,ct,aux.dpcheck(Card.GetRace),1,tp,HINTMSG_TOGRAVE)
	if #tg>0 then
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end
function s.valcheck(e,c)
	local ct=c:GetMaterial():FilterCount(Card.IsSetCard,nil,SET_LIGHTSWORN,c,SUMMON_TYPE_SYNCHRO,e:GetHandlerPlayer())
	e:GetLabelObject():SetLabel(ct)
end
function s.costfilter(c)
	return c:IsSetCard(SET_LIGHTSWORN) and c:IsMonster() and c:IsAbleToRemoveAsCost()
end
function s.toptgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) 
		and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	local ct=1
	for i=2,4 do
		if Duel.IsPlayerCanDiscardDeckAsCost(tp,i) then
			ct=ct+1
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,ct,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(#g)
end
function s.toptgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,e:GetLabel())
end
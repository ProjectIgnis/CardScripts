--ロリポー☆ヤミー
--Lollipo☆Yummy
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--If you control a Link-1 monster or a Level 2 Synchro Monster, you can Special Summon this card (from your hand)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--Shuffle 1 card from your opponent's GY into the Deck, or, if this card was Special Summoned by a Synchro Monster's effect, you can banish that card instead
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_REMOVE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
s.listed_series={SET_YUMMY}
function s.spconfilter(c)
	return (c:IsLink(1) or (c:IsType(TYPE_SYNCHRO) and c:IsLevel(2))) and c:IsFaceup()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.tgfilter(c,sp_chk)
	return c:IsAbleToDeck() or (sp_chk and c:IsAbleToRemove())
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local sp_chk=re and e:GetHandler():IsSpecialSummoned() and re:IsMonsterEffect() and re:GetHandler():IsOriginalType(TYPE_SYNCHRO)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and s.tgfilter(chkc,e:GetLabel()==1) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_GRAVE,1,nil,sp_chk) end
	e:SetLabel(sp_chk and 1 or 0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_GRAVE,1,1,nil,sp_chk)
	if sp_chk then
		Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,g,1,tp,0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,g,1,tp,0)
	else
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,tp,0)
	end
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local sp_chk=e:GetLabel()==1
	local b1=tc:IsAbleToDeck()
	local b2=sp_chk and tc:IsAbleToRemove()
	if not (b1 or b2) then return end
	local op=nil
	if sp_chk then
		op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,2)},
			{b2,aux.Stringid(id,3)})
	else
		op=1
	end
	if op==1 then
		--Shuffle it into the Deck
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	elseif op==2 then
		--Banish it
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
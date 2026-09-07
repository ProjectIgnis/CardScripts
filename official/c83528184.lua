--JP name
--GMX Associate Noma
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If this card is Special Summoned by a monster effect: You can target 1 card each from your GY and your opponent's GY; place each card on either the top or bottom of the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return re and re:IsMonsterEffect() end)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	--If a monster is Normal or Special Summoned to your opponent's field, while this card is in your Monster Zone (except during the Damage Step): You can Fusion Summon 1 "GMX" Fusion Monster from your Extra Deck, by shuffling its materials from your field, GY, and/or banishment into the Deck
	local fusion_params={
			fusfilter=function(c) return c:IsSetCard(SET_GMX) end,
			matfilter=Fusion.OnFieldMat(Card.IsAbleToDeck),
			extrafil=function(e,tp,mg) return Duel.GetMatchingGroup(aux.NecroValleyFilter(Fusion.IsMonsterFilter(Card.IsFaceup,Card.IsAbleToDeck)),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil) end,
			extraop=Fusion.ShuffleMaterial,
			extratg=s.extratg
		}
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_FUSION_SUMMON+CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e2a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2a:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2a:SetCode(EVENT_SUMMON_SUCCESS)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetCountLimit(1,{id,1})
	e2a:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return eg:IsExists(Card.IsControler,1,nil,1-tp) end)
	e2a:SetTarget(Fusion.SummonEffTG(fusion_params))
	e2a:SetOperation(Fusion.SummonEffOP(fusion_params))
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)
end
s.listed_series={SET_GMX}
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetTargetGroup(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetControler),0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetControler),1,tp,HINTMSG_TODECK)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,2,tp,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==0 then return end
	local op,sequence=nil
	local your_g,opp_g=tg:Split(Card.IsControler,nil,tp)
	if #your_g>0 then
		s.place_on_top_or_bottom(your_g,tp,tp)
	end
	if #opp_g>0 then
		s.place_on_top_or_bottom(opp_g,1-tp,tp)
	end
end
function s.place_on_top_or_bottom(group,owner,trig_player)
	local op=nil
	if Duel.GetFieldGroupCount(owner,LOCATION_DECK,0)==0 then
		op=1
	else
		local offset=(owner~=trig_player) and 2 or 0
		op=Duel.SelectEffect(trig_player,
			{true,aux.Stringid(id,2+offset)},
			{true,aux.Stringid(id,3+offset)})
	end
	local sequence=op==1 and SEQ_DECKTOP or SEQ_DECKBOTTOM
	Duel.SendtoDeck(group,nil,sequence,REASON_EFFECT)
	if op==1 then Duel.ConfirmDecktop(owner,1) end
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_REMOVED)
end
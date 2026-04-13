--ウィッチクラフト・セレブレーション
--Witchcrafter Celebration
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects;
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--During your End Phase, if you control a "Witchcrafter" monster, while this card is in your GY: You can add this card to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_WITCHCRAFTER),tp,LOCATION_MZONE,0,1,nil) end)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_WITCHCRAFTER}
function s.desfilter(c,opp)
	return (c:IsSetCard(SET_WITCHCRAFTER) and c:IsMonster() and c:IsFaceup()) or c:IsControler(opp)
end
function s.matfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAbleToDeck()
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(aux.NecroValleyFilter(s.matfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_ONFIELD,nil,1-tp)
	--● Destroy 1 "Witchcrafter" monster you control and 1 card your opponent controls
	local b1=#g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetControler),0)
	--● Fusion Summon 1 "Witchcrafter" Fusion Monster from your Extra Deck, by shuffling Spellcaster monsters from your GY and/or banishment into the Deck
	local fusion_params={
			fusfilter=function(c) return c:IsSetCard(SET_WITCHCRAFTER) end,
			matfilter=aux.FALSE,
			extrafil=s.fextra,
			extraop=Fusion.ShuffleMaterial
		}
	local b2=Fusion.SummonEffTG(fusion_params)(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_DESTROY)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,tp,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
		Fusion.SummonEffTG(fusion_params)(e,tp,eg,ep,ev,re,r,rp,1)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--● Destroy 1 "Witchcrafter" monster you control and 1 card your opponent controls
		local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_ONFIELD,nil,1-tp)
		if #g<2 or g:GetClassCount(Card.GetControler)<2 then return end
		local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetControler),1,tp,HINTMSG_DESTROY)
		if #sg==2 then
			Duel.HintSelection(sg)
			Duel.Destroy(sg,REASON_EFFECT)
		end
	elseif op==2 then
		--● Fusion Summon 1 "Witchcrafter" Fusion Monster from your Extra Deck, by shuffling Spellcaster monsters from your GY and/or banishment into the Deck
		local fusion_params={
			fusfilter=function(c) return c:IsSetCard(SET_WITCHCRAFTER) end,
			matfilter=aux.FALSE,
			extrafil=s.fextra,
			extraop=Fusion.ShuffleMaterial
		}
		Fusion.SummonEffOP(fusion_params)(e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
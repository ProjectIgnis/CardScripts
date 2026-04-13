--ウィッチクラフト・テラコッタン
--Witchcrafter Terracottan
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If this card is in your hand: You can target 1 "Witchcrafter" card in your GY, except "Witchcrafter Terracottan"; add it to your hand, and if you do, Special Summon this card, also you cannot Special Summon from the Extra Deck for the rest of this turn, except "Witchcrafter" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.thsptg)
	e1:SetOperation(s.thspop)
	c:RegisterEffect(e1)
	--During your Main Phase: You can Fusion Summon 1 "Witchcrafter" Fusion Monster from your Extra Deck, using monsters from your hand or field
	local fusion_params=aux.FilterBoolFunction(Card.IsSetCard,SET_WITCHCRAFTER)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(Fusion.SummonEffTG(fusion_params))
	e2:SetOperation(Fusion.SummonEffOP(fusion_params))
	c:RegisterEffect(e2)
end
s.listed_series={SET_WITCHCRAFTER}
s.listed_names={id}
function s.thfilter(c)
	return c:IsSetCard(SET_WITCHCRAFTER) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.thfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.thspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	--You cannot Special Summon from the Extra Deck for the rest of this turn, except "Witchcrafter" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(SET_WITCHCRAFTER) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
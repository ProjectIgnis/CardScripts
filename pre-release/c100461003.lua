--未来への希望－フューチャーヴィジョン
--Hope for the Future
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If you control a "Neos" Fusion Monster or "Elemental HERO Neos": Discard 1 card; Fusion Summon 1 Fusion Monster from your Extra Deck that mentions a "HERO" monster as material, using monsters from your hand, Deck, or field
	local fusion_params={
		fusfilter=function(c)
			return c:ListsArchetypeAsMaterial(SET_HERO)
		end,
		matfilter=function(c)
			return not c:HasFlagEffect(id)
		end,
		extrafil=function(e,tp,mg)
			return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil)
		end,
		extratg=function(e,tp,eg,ep,ev,re,r,rp,chk)
			if chk==0 then return true end
			Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_ONFIELD)
		end
	}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.condition)
	e1:SetCost(Cost.Discard(s.costfilter(fusion_params),true))
	e1:SetTarget(Fusion.SummonEffTG(fusion_params))
	e1:SetOperation(Fusion.SummonEffOP(fusion_params))
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--If you control a "Neos" Fusion Monster: You can banish this card from your GY, then target 1 face-up card your opponent controls; negate its effects until the end of this turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.discon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e2)
end
s.listed_series={SET_NEOS,SET_HERO}
s.listed_names={CARD_NEOS}
function s.conditionfilter(c)
	return ((c:IsSetCard(SET_NEOS) and c:IsFusionMonster()) or c:IsCode(CARD_NEOS)) and c:IsFaceup()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.conditionfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.costfilter(fusion_params)
	return function(c,e,tp)
		c:RegisterFlagEffect(id,0,0,1)
		local res=Fusion.SummonEffTG(fusion_params)(e,tp,nil,tp,0,nil,0,tp,0)
		c:ResetFlagEffect(id)
		return res
	end
end
function s.disconfilter(c)
	return c:IsSetCard(SET_NEOS) and c:IsFusionMonster() and c:IsFaceup()
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.disconfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsNegatable() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,tp,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsNegatable() then
		--Negate its effects until the end of this turn
		tc:NegateEffects(e:GetHandler(),RESET_PHASE|PHASE_END,true)
	end
end
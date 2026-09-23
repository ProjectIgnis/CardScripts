--溟淵方界神アビス・ヴァグラーダ
--Abyss Vagrada the Abyssal Cubic Lord
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 3 "Cubic" monsters
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_CUBIC),3)
	--Gains 1000 ATK for each "Vijam the Cubic Seed" in your GY, also unaffected by the activated effects of monsters with ATK less than this card
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1a:SetCode(EFFECT_UPDATE_ATTACK)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetValue(function(e,c)
		return 1000*Duel.GetMatchingGroupCount(Card.IsCode,c:GetControler(),LOCATION_GRAVE,0,nil,CARD_VIJAM)
	end)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_IMMUNE_EFFECT)
	e1b:SetValue(function(e,te)
		return te:IsActivated() and te:IsMonsterEffect() and te:GetCardAttack()<e:GetHandler():GetAttack()
	end)
	c:RegisterEffect(e1b)
	--(Quick Effect): You can return this card to the Extra Deck, and if you do, Special Summon 3 "Cubic" monsters from your GY, and if you do that, add 1 "Cubic" card from your Deck to your hand. You can only use this effect of "Abyss Vagrada the Abyssal Cubic Lord" once per turn, also you cannot Special Summon from the Extra Deck the turn you activate this effect, except Fusion Monsters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cost)
	e2:SetTarget(s.spthtg)
	e2:SetOperation(s.spthop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
	--Check if a non-Fusion Monster is Special Summoned from the Extra Deck
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(c) return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsFusionMonster() end)
end
s.listed_series={SET_CUBIC}
s.material_setcode={SET_CUBIC}
s.listed_names={CARD_VIJAM}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	--You cannot Special Summon from the Extra Deck the turn you activate this effect, except Fusion Monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c)
		return c:IsLocation(LOCATION_EXTRA) and not c:IsFusionMonster()
	end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_CUBIC) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.thfilter(c)
	return c:IsSetCard(SET_CUBIC) and c:IsAbleToHand()
end
function s.spthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtra() and Duel.GetMZoneCount(tp,c)>=3
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,3,nil,e,tp)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) end
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.spthop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and c:IsLocation(LOCATION_EXTRA)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=3 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local spg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,3,3,nil,e,tp)
		if #spg==3 and Duel.SpecialSummon(spg,0,tp,tp,false,false,POS_FACEUP)==3 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local hg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #hg>0 then
				Duel.SendtoHand(hg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,hg)
			end
		end
	end
end
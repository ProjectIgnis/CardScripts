--インフェルニティ・デス・ガンマン
--Infernity Doom Slinger
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--During your Main Phase: You can Special Summon 1 Fiend monster from your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--If you have no cards in your hand (Quick Effect): You can banish this card from your GY; your opponent chooses 1 of these effects for you to apply
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp) return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 end)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return true end Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,4000) end)
	e2:SetOperation(s.effop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local top_card=Duel.GetDecktopGroup(tp,1):GetFirst()
	local b1=top_card
	local b2=true
	local op=Duel.SelectEffect(1-tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	local c=e:GetHandler()
	if op==1 then
		--Reveal the top card of your Deck, and if it is a monster, your opponent takes any effect damage you would have taken this turn instead. Otherwise, you take 4000 damage
		Duel.ConfirmDecktop(tp,1)
		if top_card:IsMonster() then
			--Your opponent takes any effect damage you would have taken this turn instead
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,4))
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_REFLECT_DAMAGE)
			e1:SetTargetRange(1,0)
			e1:SetValue(function(e,_,_,r) return (r&REASON_EFFECT)==REASON_EFFECT end)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
		else
			Duel.Damage(tp,4000,REASON_EFFECT)
		end
	elseif op==2 then
		--You take no effect damage this turn
		local e2a=Effect.CreateEffect(c)
		e2a:SetDescription(aux.Stringid(id,5))
		e2a:SetType(EFFECT_TYPE_FIELD)
		e2a:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e2a:SetCode(EFFECT_CHANGE_DAMAGE)
		e2a:SetTargetRange(1,0)
		e2a:SetValue(s.damval)
		e2a:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e2a,tp)
		local e2b=e2a:Clone()
		e2b:SetCode(EFFECT_NO_EFFECT_DAMAGE)
		Duel.RegisterEffect(e2b,tp)
	end
end
function s.damval(e,re,val,r,rp,rc)
	if (r&REASON_EFFECT)>0 then
		return 0
	else
		return val
	end
end
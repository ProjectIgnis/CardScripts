--光帰への契り
--Sennet Per Akh
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 "Sennet" monster from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--If you discard a "Sennet" Ritual Monster(s) while this card is in your GY: You can banish this card; Special Summon 1 non-Effect Fusion Monster from your Extra Deck with ATK less than or equal to any of the discarded monsters' as a Normal Monster Card, but for the rest of this turn, it cannot attack directly, also you cannot activate non-Zombie monster effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_DISCARD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Prevent the non-Effect Fusion Monster Special Summoned as a Normal Monster Card from being returned to the hand or Main Deck as cost
	aux.GlobalCheck(s,function()
		Card.IsAbleToHandAsCost=(function()
			local oldfunc=Card.IsAbleToHandAsCost
			return function(c,...)
				if c:HasFlagEffect(id) then
					return false
				end
				return oldfunc(c,...)
			end
		end)()
		Card.IsAbleToDeckAsCost=(function()
			local oldfunc=Card.IsAbleToDeckAsCost
			return function(c,...)
				if c:HasFlagEffect(id) then
					return false
				end
				return oldfunc(c,...)
			end
		end)()
	end)
end
s.listed_series={SET_SENNET}
function s.thfilter(c)
	return c:IsSetCard(SET_SENNET) and c:IsMonster() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.spconfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsSetCard(SET_SENNET) and c:IsRitualMonster()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.spconfilter,1,nil,tp)
end
function s.spfilter(c,e,tp,max_atk)
	return c:IsNonEffectMonster() and c:IsFusionMonster() and c:IsAttackBelow(max_atk)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local _,max_atk=eg:Filter(s.spconfilter,nil,tp):GetMaxGroup(Card.GetTextAttack)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,max_atk) end
	e:GetChainData().max_atk=max_atk
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local max_atk=e:GetChainData().max_atk
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,max_atk):GetFirst()
	if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
		local original_type=sc:GetType()
		sc:Type((original_type&~TYPE_FUSION)|TYPE_NORMAL)
		sc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,original_type,aux.Stringid(id,2))
		--Reset its type back to the original when it stops being face-up in the Monster Zone
		local e0a=Effect.CreateEffect(c)
		e0a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e0a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e0a:SetCode(EVENT_ADJUST)
		e0a:SetCondition(function()
			return not sc:HasFlagEffect(id)
		end)
		e0a:SetOperation(function()
			sc:Type(original_type)
			e0a:Reset()
		end)
		Duel.RegisterEffect(e0a,tp)
		local e0b=Effect.CreateEffect(c)
		e0b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e0b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e0b:SetCode(EFFECT_SEND_REPLACE)
		e0b:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
			local g=eg:Filter(Card.HasFlagEffect,nil,id)
			if chk==0 then return #g>0 end
			for tc in g:Iter() do
				tc:Type(tc:GetFlagEffectLabel(id))
			end
			e0b:Reset()
			return true
		end)
		e0b:SetValue(aux.FALSE)
		Duel.RegisterEffect(e0b,tp)
		--But for the rest of this turn, it cannot attack directly
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3207)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		sc:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
	--Also you cannot activate non-Zombie monster effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetTargetRange(1,0)
	e2:SetValue(function(e,re)
		return re:IsMonsterEffect() and re:GetHandler():IsRaceExcept(RACE_ZOMBIE)
	end)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
end

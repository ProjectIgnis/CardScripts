--鬼神童鵄 タマヨリ
--Ashtrata Tamayori
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If this card is Normal or Special Summoned: You can Special Summon 1 "Ashtra" non-Tuner from your Deck in Defense Position, then you can change 1 face-up monster you control to face-down Defense Position, also you cannot Special Summon from the Extra Deck for the rest of this turn, except Synchro Summon using a Level 1 Tuner
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION+CATEGORY_SET)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetCountLimit(1,{id,0})
	e1a:SetTarget(s.sptg)
	e1a:SetOperation(s.spop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--If an "Ashtra" and/or face-down card(s) you control would be destroyed by card effect, you can banish this card from your GY instead
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.reptg)
	e2:SetValue(function(e,c)
		return s.repfilter(c,e:GetHandlerPlayer())
	end)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_CARD,0,id)
		Duel.Remove(e:GetHandler(),nil,REASON_EFFECT|REASON_REPLACE)
	end)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ASHTRA}
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_ASHTRA) and not c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_MZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
			Duel.ShuffleDeck(tp)
			if Duel.IsExistingMatchingCard(Card.IsCanTurnSet,tp,LOCATION_MZONE,0,1,nil)
				and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
				local sg=Duel.SelectMatchingCard(tp,Card.IsCanTurnSet,tp,LOCATION_MZONE,0,1,1,nil)
				if #sg>0 then
					Duel.HintSelection(sg)
					Duel.BreakEffect()
					Duel.ChangePosition(sg,POS_FACEDOWN_DEFENSE)
				end
			end
		end
	end
	local c=e:GetHandler()
	--You cannot Special Summon from the Extra Deck for the rest of this turn, except by Synchro Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,tp,st,pos,target_p,sumeff,proc_eff)
		return c:IsLocation(LOCATION_EXTRA) and (st&SUMMON_TYPE_SYNCHRO~=SUMMON_TYPE_SYNCHRO or proc_eff==nil)
	end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--"Clock Lizard" Check
	aux.addTempLizardCheck(c,tp,aux.TRUE)
	--You must include a Level 1 Tuner as material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e2:SetTargetRange(LOCATION_MZONE|LOCATION_HAND,0)
	e2:SetTarget(function(e,c,t)
		return not (c:IsLevel(1) and c:IsType(TYPE_TUNER))
	end)
	e2:SetOperation(s.synop)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function s.lv1filter(c,sc)
	return c:IsLevel(1) or c:GetSynchroLevel(sc)==1
end
function s.ntglv1tunerfilter(c,sc,tp)
	return s.lv1filter(c,sc) and c:IsType(TYPE_TUNER,sc,SUMMON_TYPE_SYNCHRO,tp)
end
function s.synop(e,tg,ntg,sg,lv,sc,tp)
	return e:GetHandlerPlayer()==1-tp or tg:IsExists(s.lv1filter,1,nil,sc) or ntg:IsExists(s.ntglv1tunerfilter,1,nil,sc,tp)
end
function s.repfilter(c,tp)
	return (c:IsSetCard(SET_ASHTRA) or c:IsFacedown()) and c:IsControler(tp) and c:IsOnField()
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
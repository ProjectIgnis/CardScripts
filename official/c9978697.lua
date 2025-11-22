--Ｘ－セイバー ペリナ
--X-Saber Perina
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 2 "X-Saber" monsters from your Deck, except "X-Saber Perina", but destroy them during the End Phase
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetCountLimit(1,id)
	e1a:SetCost(Cost.SelfToGrave)
	e1a:SetTarget(s.sptg)
	e1a:SetOperation(s.spop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--Apply an effect to the "X-Saber" Synchro Monster that used this card as material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.effcon)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_X_SABER}
s.listed_names={id}
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_X_SABER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetMZoneCount(tp,e:GetHandler())>=2
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,2,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,2,tp,LOCATION_MZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,2,2,nil,e,tp)
	if #g==2 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)==2 then
		--Destroy them during the End Phase
		aux.DelayedOperation(g,PHASE_END,id,e,tp,function(ag) Duel.Destroy(ag,REASON_EFFECT) end,nil,0,0,aux.Stringid(id,2))
	end
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	if not (r==REASON_SYNCHRO and (Duel.IsAbleToEnterBP() or (Duel.IsBattlePhase() and not Duel.IsEndStep()))) then return false end
	local c=e:GetHandler()
	local sync=c:GetReasonCard()
	if not (c:IsLocation(LOCATION_GRAVE) and sync:IsSetCard(SET_X_SABER)) then return false end
	e:SetLabelObject(sync)
	sync:RegisterFlagEffect(id,RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET),0,1)
	return true
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local sync=e:GetLabelObject()
	if chk==0 then
		return sync:HasFlagEffect(id) and not (sync:IsHasEffect(EFFECT_EXTRA_ATTACK) and sync:IsHasEffect(EFFECT_DIRECT_ATTACK))
	end
	sync:CreateEffectRelation(e)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local sync=e:GetLabelObject()
	if not sync:IsRelateToEffect(e) then return end
	local b1=not sync:IsHasEffect(EFFECT_EXTRA_ATTACK)
	local b2=not sync:IsHasEffect(EFFECT_DIRECT_ATTACK)
	if not (b1 or b2) then return end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,3)},
		{b2,aux.Stringid(id,4)})
	local desc=op==1 and 3201 or 3205
	local eff_code=op==1 and EFFECT_EXTRA_ATTACK or EFFECT_DIRECT_ATTACK
	--It can make a second attack during each Battle Phase OR it can attack directly
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(desc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(eff_code)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	sync:RegisterEffect(e1)
end
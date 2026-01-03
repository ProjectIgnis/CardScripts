--王者の鼓動
--Champion's Pulse
--Scripted by The Razgriz
local s,id=GetID()
local CARD_HOT_RED_DRAGON_ARCHFIEND=39765958
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	e1:SetHintTiming(0,TIMING_BATTLE_START)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_RED_DRAGON_ARCHFIEND,CARD_HOT_RED_DRAGON_ARCHFIEND}
function s.spfilter(c,e,tp,mmz_chk)
	if not (c:IsCode(CARD_RED_DRAGON_ARCHFIEND,CARD_HOT_RED_DRAGON_ARCHFIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if c:IsLocation(LOCATION_GRAVE) then
		return mmz_chk
	else
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	end
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsBattlePhase(1-tp)
	local event_chaining,_,event_player,event_value,event_reason_effect=Duel.CheckEvent(EVENT_CHAINING,true)
	local b2=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
		and event_chaining and event_player==1-tp and event_reason_effect:IsMonsterEffect() and Duel.IsChainDisablable(event_value)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,nil,e,tp,Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_RECOVER)
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,1000)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE+CATEGORY_DESTROY)
		e:SetLabel(op,event_value)
		local rc=event_reason_effect:GetHandler()
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA|LOCATION_GRAVE)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,rc,1,tp,0)
		if rc:IsDestructable() and rc:IsRelateToEffect(event_reason_effect) then
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,rc,1,tp,0)
		end
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op,event_value=e:GetLabel()
	if op==1 then
		--Your opponent gains 1000 LP, then end the Battle Phase
		if Duel.Recover(1-tp,1000,REASON_EFFECT)>0 then
			Duel.BreakEffect()
			Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE|PHASE_BATTLE_STEP,1)
		end
	elseif op==2 then
		--Special Summon 1 "Red Dragon Archfiend" or "Hot Red Dragon Archfiend" from your Extra Deck or GY, and if you do, negate that activated effect, and if you do that, destroy that monster
		local trig_eff=Duel.GetChainInfo(event_value,CHAININFO_TRIGGERING_EFFECT)
		local rc=trig_eff:GetHandler()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,1,nil,e,tp,Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
		if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.NegateEffect(event_value)
			and rc:IsRelateToEffect(trig_eff) then
			Duel.Destroy(rc,REASON_EFFECT)
		end
	end
end
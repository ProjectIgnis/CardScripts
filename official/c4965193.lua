--極征竜－シャスマティス
--Chasma, Dragon Ruler of Auroras
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 7 Dragon monsters
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_DRAGON),7,2)
	--This effect becomes the effect of a Level 7 "Dragon Ruler" monster that activates by discarding itself
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.AND(s.applycost,Cost.Detach(1)))
	e1:SetTarget(s.applytg)
	e1:SetOperation(s.applyop)
	c:RegisterEffect(e1)
	--Special Summon 1 Level 7 "Dragon Ruler" from your GY or banishment
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_DRAGON_RULER}
function s.runfn(fn,eff,tp,chk)
	return not fn or fn(eff,tp,Group.CreateGroup(),PLAYER_NONE,0,nil,REASON_EFFECT,PLAYER_NONE,chk)
end
function s.applyfilter(c,tp)
	if not (c:IsSetCard(SET_DRAGON_RULER) and c:IsLevel(7) and c:IsAbleToGraveAsCost()) then return false end
	for _,eff in ipairs({c:GetOwnEffects()}) do
		if eff:HasSelfDiscardCost() and s.runfn(eff:GetCondition(),eff,tp,0) and s.runfn(eff:GetTarget(),eff,tp,0) then return true end
	end
	return false
end
function s.applycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.applyfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sc=Duel.SelectMatchingCard(tp,s.applyfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	local effs={}
	local options={}
	for _,eff in ipairs({sc:GetOwnEffects()}) do
		if eff:HasSelfDiscardCost() then
			table.insert(effs,eff)
			local eff_chk=s.runfn(eff:GetCondition(),eff,tp,0) and s.runfn(eff:GetTarget(),eff,tp,0)
			table.insert(options,{eff_chk,eff:GetDescription()})
		end
	end
	local op=#options==1 and 1 or Duel.SelectEffect(tp,table.unpack(options))
	local te=effs[op]
	e:SetLabelObject(te)
	Duel.SendtoGrave(sc,REASON_COST)
end
function s.applytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local te=e:GetLabelObject()
	if chkc then return te and te:GetTarget() and te:GetTarget()(e,tp,eg,ep,ev,re,r,rp,0,chkc) end
	if chk==0 then return true end
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	e:SetProperty(te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and EFFECT_FLAG_CARD_TARGET or 0)
	local tg=te:GetTarget()
	if tg then
		tg(e,tp,eg,ep,ev,re,r,rp,1)
		te:SetLabel(e:GetLabel())
		te:SetLabelObject(e:GetLabelObject())
		Duel.ClearOperationInfo(0)
	end
	e:SetLabelObject(te)
end
function s.applyop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	local op=te:GetOperation()
	if op then
		e:SetLabel(te:GetLabel())
		e:SetLabelObject(te:GetLabelObject())
		op(e,tp,eg,ep,ev,re,r,rp)
	end
	e:SetProperty(0)
	e:SetLabel(0)
	e:SetLabelObject(nil)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp))
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_DRAGON_RULER) and c:IsLevel(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsFaceup()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
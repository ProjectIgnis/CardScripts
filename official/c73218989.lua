--ブラックフェザー・アサルト・ドラゴン
--Black-Winged Assault Dragon
--scripted by Cybercatman
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_FEATHER)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner Synchro Monster + 1+ non-Tuner monsters
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_SYNCHRO),1,1,Synchro.NonTuner(nil),1,99)
	--Must be either Synchro Summoned, or Special Summoned from your Extra Deck by banishing 1 Tuner Synchro Monster and 1 "Black-Winged Dragon" from your face-up Monster Zone and/or GY
	c:AddMustBeSynchroSummoned()
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.spcon)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)
	--Each time your opponent activates a monster effect, place 1 Black Feather Counter on this card when that effect resolves, and if you do, inflict 700 damage to your opponent
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1a:SetCode(EVENT_CHAINING)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetOperation(aux.chainreg)
	c:RegisterEffect(e1a)
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1b:SetCode(EVENT_CHAIN_SOLVED)
	e1b:SetRange(LOCATION_MZONE)
	e1b:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return ep==1-tp and re:IsMonsterEffect() and e:GetHandler():HasFlagEffect(1)
	end)
	e1b:SetOperation(s.damop)
	c:RegisterEffect(e1b)
	--During your opponent's turn (Quick Effect): You can Tribute this card with 4 or more Black Feather Counters on it; destroy all cards on the field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e2:SetCondition(function(e,tp)
		return Duel.IsTurnPlayer(1-tp)
	end)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.counter_list={COUNTER_FEATHER}
s.listed_names={CARD_BLACK_WINGED_DRAGON}
s.synchro_tuner_required=1
function s.spfilter(c,tp)
	return (c:IsCompositeType(TYPE_SYNCHRO|TYPE_TUNER) or c:IsCode(CARD_BLACK_WINGED_DRAGON))
		and c:IsFaceup() and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true,true)
end
function s.rescon(sg,e,tp)
	if #sg~=2 or Duel.GetLocationCountFromEx(tp,tp,sg,e:GetHandler())==0 then return false end
	local a,b=sg:GetFirst(),sg:GetNext()
	return (a:IsCompositeType(TYPE_SYNCHRO|TYPE_TUNER) and b:IsCode(CARD_BLACK_WINGED_DRAGON))
		or (b:IsCompositeType(TYPE_SYNCHRO|TYPE_TUNER) and a:IsCode(CARD_BLACK_WINGED_DRAGON))
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil,tp)
	return aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil,tp)
	local g=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_REMOVE,nil,nil,true)
	if #g>0 then
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if g then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:AddCounter(COUNTER_FEATHER,1) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.Damage(1-tp,700,REASON_EFFECT)
	end
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetCounter(COUNTER_FEATHER)>=4 and c:IsReleasable() end
	Duel.Release(c,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

--捕食植物デェアデビル
--Predaplant Dheadevil
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 1 "Predaplant" monster + 1 Level 1 monster
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_PREDAPLANT),aux.FilterBoolFunction(Card.IsLevel,1))
	c:AddMustFirstBeFusionSummoned()
	--Must first be either Fusion Summoned, or Special Summoned (from your Extra Deck) by Tributing 1 monster on either field with a Predator Counter and 1 "Predaplant" monster you control
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.selfspcon)
	e0:SetTarget(s.selfsptg)
	e0:SetOperation(s.selfspop)
	c:RegisterEffect(e0)
	--During the Main Phase, if this card was Special Summoned this turn (Quick Effect): You can target Spells/Traps on the field, up to the number of monsters with a Predator Counter; destroy them
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return Duel.IsMainPhase() and e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN) end)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e1)
end
s.listed_series={SET_PREDAPLANT}
s.counter_list={COUNTER_PREDATOR}
s.material_setcode=SET_PREDAPLANT
function s.selfspcostfilter(c,tp,fc)
	return ((c:IsSetCard(SET_PREDAPLANT) and c:IsControler(tp)) or c:HasCounter(COUNTER_PREDATOR)) and c:IsReleasable()
		and c:IsCanBeFusionMaterial(fc,MATERIAL_FUSION)
end
function s.rescon(sg,e,tp,mg)
	return Duel.GetLocationCountFromEx(tp,tp,sg,e:GetHandler())>0 and sg:IsExists(s.predaplantchkfilter,1,nil,tp)
		and sg:IsExists(Card.HasCounter,1,nil,COUNTER_PREDATOR)
end
function s.predaplantchkfilter(c,tp)
	return c:IsSetCard(SET_PREDAPLANT) and c:IsControler(tp)
end
function s.selfspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.selfspcostfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp,c)
	return aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.selfspcostfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp,c)
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_RELEASE,nil,nil,true)
	if #sg==2 then
		e:SetLabelObject(sg)
		return true
	end
	return false
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if g then
		Duel.Release(g,REASON_COST|REASON_MATERIAL)
	end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsSpellTrap() end
	local max_count=Duel.GetMatchingGroupCount(Card.HasCounter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,COUNTER_PREDATOR)
	if chk==0 then return max_count>0 and Duel.IsExistingTarget(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,max_count,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
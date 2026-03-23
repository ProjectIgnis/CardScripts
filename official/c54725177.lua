--銀河眼の輝光子竜
--Galaxy-Eyes Photon Change Dragon
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--You can Special Summon this card (from your hand) by Tributing 2 face-up monsters on either field with 2000 or more ATK, including a monster you control. You can only Special Summon "Galaxy-Eyes Photon Change Dragon" once per turn this way
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.selfspcon)
	e1:SetTarget(s.selfsptg)
	e1:SetOperation(s.selfspop)
	c:RegisterEffect(e1)
	--During the Main Phase (Quick Effect): You can banish this card you control; Special Summon 1 "Galaxy-Eyes Photon Dragon" from your Deck or GY, then you can banish 1 monster your opponent controls that was Special Summoned from the Extra Deck until the End Phase. You can only use this effect of "Galaxy-Eyes Photon Change Dragon" once per turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function() return Duel.IsMainPhase() end)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.gepdsptg)
	e2:SetOperation(s.gepdspop)
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_GALAXYEYES_P_DRAGON}
function s.selfspcostfilter(c)
	return c:IsAttackAbove(2000) and c:IsFaceup() and c:IsReleasable()
end
function s.rescon(sg,e,tp,mg)
	return Duel.GetMZoneCount(tp,sg)>0 and sg:IsExists(Card.IsControler,1,nil,tp)
end
function s.selfspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.selfspcostfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	return #g>0 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.selfspcostfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_RELEASE,nil,nil,true)
	if #sg>0 then
		e:SetLabelObject(sg)
		return true
	end
	return false
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if g then
		Duel.Release(g,REASON_COST)
	end
end
function s.gepdspfilter(c,e,tp)
	return c:IsCode(CARD_GALAXYEYES_P_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.gepdsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		and Duel.IsExistingMatchingCard(s.gepdspfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_MZONE)
end
function s.rmvfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsAbleToRemove()
end
function s.gepdspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.gepdspfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0
		and Duel.IsExistingMatchingCard(s.rmvfilter,tp,0,LOCATION_MZONE,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rg=Duel.SelectMatchingCard(tp,s.rmvfilter,tp,0,LOCATION_MZONE,1,1,nil)
		if #rg>0 then
			Duel.HintSelection(rg)
			Duel.BreakEffect()
			--Banish 1 monster your opponent controls that was Special Summoned from the Extra Deck until the End Phase
			aux.RemoveUntil(rg,nil,REASON_EFFECT,PHASE_END,id,e,tp,aux.DefaultFieldReturnOp)
		end
	end
end
--天穹覇龍ドラゴアセンション (Manga)
--Ascension Sky Dragon (Manga)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner + 1 or more non-Tuner monsters
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--ATK becomes 1000 x number of cards in your hand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,c) return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)*1000 end)
	c:RegisterEffect(e1)
	--Return this card to the Extra Deck and Special Summon its materials
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.desreptg)
	e2:SetOperation(s.desrepop)
	c:RegisterEffect(e2)
end
function s.mgfilter(c,e,tp,sync)
	return c:IsControler(tp) and c:IsLocation(LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED)
		and c:GetReason()&(REASON_MATERIAL|REASON_SYNCHRO)==(REASON_MATERIAL|REASON_SYNCHRO) and c:GetReasonCard()==sync
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local sumtype=c:GetSummonType()
	local mg=c:GetMaterial():Filter(aux.NecroValleyFilter(s.mgfilter),nil,e,tp,c)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if c:GetSequence()<5 then ft=ft+1 end
	if chk==0 then return not (c:IsReason(REASON_REPLACE) or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) and c:IsFaceup() 
		and c:IsAbleToExtra() and #mg>0 and #mg<=ft and sumtype==SUMMON_TYPE_SYNCHRO end
	if #mg>0 then 
		return true
	else 
		return false 
	end
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sumtype=c:GetSummonType()
	local mg=c:GetMaterial():Filter(aux.NecroValleyFilter(s.mgfilter),nil,e,tp,c)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if c:GetSequence()<5 then ft=ft+1 end
	Duel.Hint(HINT_CARD,tp,id)
	if Duel.SendtoDeck(c,nil,0,REASON_EFFECT|REASON_REPLACE)>0 
		and sumtype==SUMMON_TYPE_SYNCHRO and #mg>0 
		and #mg<=ft then
		Duel.SpecialSummon(mg,0,tp,tp,false,false,POS_FACEUP)
	end
end
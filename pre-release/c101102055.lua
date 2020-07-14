--電脳堺都－九竜
--Datascape Capital - Jiulong
--Scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.tftg)
	e1:SetOperation(s.tfop)
	c:RegisterEffect(e1)
end
s.listed_series={0x1248,0x248}
function s.tffilter(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x1248) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:GetHandler():IsLocation(LOCATION_HAND) then ft=ft-1 end
	if chk==0 then return ft>0 and Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.tffilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		local ct=Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(Card.IsSetCard,0x1248),tp,LOCATION_ONFIELD,0,nil)
		if ct>=2 then
			Duel.BreakEffect()
			local c=e:GetHandler()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetTargetRange(LOCATION_MZONE,0)
			e1:SetValue(200)
			e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x248))
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
		if ct>=3 and Duel.IsPlayerCanDiscardDeck(tp,3) then
			Duel.BreakEffect()
			Duel.DiscardDeck(tp,3,REASON_EFFECT)
		end
		if ct>=4 then
			local ft1=Duel.GetLocationCountFromEx(tp)
			local ft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
			local ft3=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM+TYPE_LINK)
			local ft=math.min(Duel.GetUsableMZoneCount(tp),4)
			if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
				if ft1>0 then ft1=1 end
				if ft2>0 then ft2=1 end
				if ft3>0 then ft3=1 end
				ft=1
			end
			local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
			if #sg>0 then
				local rg=aux.SelectUnselectGroup(sg,e,tp,1,ft,s.rescon(ft1,ft2,ft3,ft),1,tp,HINTMSG_SPSUMMON)
				Duel.BreakEffect()
				Duel.SpecialSummon(rg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x248) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.exfilter1(c)
	return c:IsFacedown() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
function s.exfilter2(c)
	return c:IsType(TYPE_LINK) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM))
end
function s.rescon(ft1,ft2,ft3,ft)
	return	function(sg,e,tp,mg)
				local exnpct=sg:FilterCount(s.exfilter1,nil)
				local expct=sg:FilterCount(s.exfilter2,nil)
				local groupcount=#sg
				local classcount=sg:GetClassCount(Card.GetCode)
				local res=ft2>=exnpct and ft3>=expct and ft>=groupcount and classcount==groupcount
				return res, not res
			end
end

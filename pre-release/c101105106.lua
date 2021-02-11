--スターダスト・イルミネイト
--Stardust Illuminate
--scripted by Rundas
local s,id=GetID()
function s.initial_effect(c)
	--To Grave
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--Level Change
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
end
s.listed_names={id,44508094}
s.listed_series={0xa3}
--To Grave
function s.tgfilter(c,e,tp,ss,mz)
	return c:IsAbleToGrave() or (ss and mz and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function s.ssfilter(c)
	return c:IsCode(44508094) or (aux.IsCodeListed(c,44508094) and c:IsType(TYPE_SYNCHRO))
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ss,mz=Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_MZONE,0,1,nil),Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,e,tp,ss,mz) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ss,mz):GetFirst()
	local choice=0
	if ss and mz and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then 
		choice=1 
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,tp,LOCATION_DECK)
		else Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tc,1,tp,LOCATION_DECK)
	end
	e:SetLabelObject({tc,choice})
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc,choice=table.unpack(e:GetLabelObject())
	if not tc then return end
	if choice==0 and tc:IsAbleToGrave() then Duel.SendtoGrave(tc,REASON_EFFECT)
	elseif choice==1 and Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	else return end
end
--Level Change
function s.lvfilter(c)
	return c:IsSetCard(0xa3) and c:IsMonster()
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	local tc=Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	local choice
	if tc:IsLevelAbove(2) then 
		choice=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
		else choice=Duel.SelectOption(tp,aux.Stringid(id,3))
	end
	e:SetLabelObject({tc,choice})
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c,tc,choice=e:GetHandler(),table.unpack(e:GetLabelObject())
	if not tc then return end
	if choice==0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	elseif choice==1 then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_LEVEL)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(-1)
		tc:RegisterEffect(e2)
	else return end
end
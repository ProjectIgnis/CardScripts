--覇王眷竜スターヴ・ヴェノム
--Supreme King Dragon Starving Venom
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion materials: 2 DARK Pendulum monsters
	Fusion.AddProcMixN(c,true,true,s.ffilter,2)
	--Special Summon this card by tributing the above cards you control
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit,nil,nil,nil,false)
	--Copy the name and effect of another monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCost(s.copycost)
	e1:SetTarget(s.copytg)
	e1:SetOperation(s.copyop)
	c:RegisterEffect(e1)
end
function s.ffilter(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_DARK,fc,sumtype,tp) and c:IsType(TYPE_PENDULUM,fc,sumtype,tp)
end
function s.contactfil(tp)
	return Duel.GetReleaseGroup(tp)
end
function s.contactop(g)
	Duel.Release(g,REASON_COST|REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
function s.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(41209827)==0 end
	e:GetHandler():RegisterFlagEffect(41209827,RESETS_STANDARD_PHASE_END,0,1)
end
function s.copyfilter(c)
	return c:IsMonster() and not c:IsType(TYPE_TOKEN) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) and s.copyfilter(chkc) and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(s.copyfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.copyfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,1,1,c)
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local code=tc:GetOriginalCode()
		--This card's name becomes the target's name
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
		if not tc:IsType(TYPE_TRAPMONSTER) then
			c:CopyEffect(code,RESETS_STANDARD_PHASE_END,1)
		end
	end
	--Inflict piercing battle damage to your opponent for the rest of the turn
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
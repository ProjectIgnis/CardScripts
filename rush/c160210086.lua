--セレブレード・デスワイルド
--Celeb Blade - Death Wild
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--equip
	aux.AddEquipProcedure(c,0,s.eqfilter,s.eqlimit,nil,nil,s.gainop)
	--atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(400)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_ADD_CODE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(CARD_CELEB_ROSE_WITCH)
	e2:SetOperation(s.chngcon)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_CELEB_ROSE_WITCH}
function s.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_LIGHT) and not c:IsMaximumModeSide()
end
function s.eqlimit(e,c)
	return c:IsFaceup()
end
function s.gainop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PIERCE)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
		e2:SetRange(LOCATION_SZONE)
		e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e2:SetTarget(s.eftg)
		e2:SetLabelObject(e1)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
function s.chngcon(scard,sumtype,tp)
	return ((sumtype&MATERIAL_FUSION)~=0 or (sumtype&SUMMON_TYPE_FUSION)~=0) and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,CARD_CELEB_ROSE_WITCH)
end
function s.eftg(e,c)
	return e:GetHandler():GetEquipTarget()==c
end
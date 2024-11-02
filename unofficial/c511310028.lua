--闇の淵デュプリケート・ドローン
--Duplicate Drone
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card (from your hand)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--Place 1 non-Machine monster you control face-up in your Spell & Trap Zone as a Continuous Spell
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.pltg)
	e2:SetOperation(s.plop)
	c:RegisterEffect(e2)
	--Change this card's name, Type, Attribute, Level, and ATK/DEF
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(s.cptg)
	e3:SetOperation(s.cpop)
	c:RegisterEffect(e3)
end
s.listed_names={id}
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,id),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.plfilter(c)
	return not c:IsRace(RACE_MACHINE) and c:IsFaceup() and not c:IsForbidden()
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.plfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.plfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	Duel.SelectTarget(tp,s.plfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then
		Duel.SendtoGrave(d,REASON_RULE,nil,PLAYER_NONE)
	elseif Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,tc:IsMonsterCard()) then
		--Treated as a Continuous Spell
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
		tc:RegisterEffect(e1)
	end
end
function s.cpfilter(c,hc)
	return c:IsMonsterCard() and c:IsContinuousSpell() and c:IsFaceup() and not hc:HasFlagEffect(-c:GetFieldID())
end
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and s.cpfilter(chkc,c) end
	if chk==0 then return Duel.IsExistingTarget(s.cpfilter,tp,LOCATION_SZONE,0,1,nil,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.cpfilter,tp,LOCATION_SZONE,0,1,1,nil,c)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,c,1,tp,0)
end
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not (c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e)) then return end
	local fid=tc:GetFieldID()
	c:RegisterFlagEffect(-fid,RESET_EVENT|RESETS_STANDARD,0,1)
	--While it is in the Spell & Trap Zone, the name, Type, Attribute, Level, and ATK/DEF of this card become the same as that card's
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetCondition(function() return c:HasFlagEffect(-fid) and tc:IsLocation(LOCATION_SZONE) end)
	e1:SetValue(tc:GetCode())
	e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetValue(tc:GetOriginalRace())
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e3:SetValue(tc:GetOriginalAttribute())
	c:RegisterEffect(e3)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CHANGE_LEVEL)
	e4:SetValue(tc:GetOriginalLevel())
	c:RegisterEffect(e4)
	local e5=e1:Clone()
	e5:SetCode(EFFECT_SET_ATTACK_FINAL)
	e5:SetValue(tc:GetTextAttack())
	c:RegisterEffect(e5)
	local e6=e1:Clone()
	e6:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e6:SetValue(tc:GetTextDefense())
	c:RegisterEffect(e6)
	--Destroy this card when that card leaves the field
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_LEAVE_FIELD)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(function(e,tp,eg) return eg:IsContains(tc) and c:HasFlagEffect(-fid) end)
	e7:SetOperation(function(e) Duel.Destroy(e:GetHandler(),REASON_EFFECT) end)
	e7:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e7)
end
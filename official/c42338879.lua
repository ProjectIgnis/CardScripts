--こけコッコ
--Cockadoodledoo
local s,id=GetID()
function s.initial_effect(c)
	--If there are no monsters on the field, you can Special Summon this card (from your hand) as a Level 3 monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.lv3spcon)
	e1:SetOperation(s.spop(3))
	e1:SetLabelObject({function(c) c:AssumeProperty(ASSUME_LEVEL,3) end})
	c:RegisterEffect(e1)
	--If your opponent controls a monster and you control no cards, you can Special Summon this card (from your hand) as a Level 4 monster
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCondition(s.lv4spcon)
	e2:SetOperation(s.spop(4))
	e2:SetLabelObject({function(c) c:AssumeProperty(ASSUME_LEVEL,4) end})
	c:RegisterEffect(e2)
	--If this face-up card would leave the field, banish it instead
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e3:SetCondition(function(e) return e:GetHandler():IsFaceup() end)
	e3:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e3)
end
function s.lv3spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(0,LOCATION_MZONE,LOCATION_MZONE)==0
end
function s.lv4spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0
end
function s.spop(lv)
	return function(e,tp,eg,ep,ev,re,r,rp,c)
		c:AssumeProperty(ASSUME_LEVEL,lv)
		--Special Summon this card (from your hand) as a Level 3 or 4 monster
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT|(RESETS_STANDARD_DISABLE&~RESET_TOFIELD))
		c:RegisterEffect(e1)
	end
end
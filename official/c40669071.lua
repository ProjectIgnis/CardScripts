--エクスコード・トーカー
--Excode Talker
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_CYBERSE),2)
	--lock zones
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.lzcon)
	e1:SetTarget(s.lztg)
	e1:SetOperation(s.lzop)
	c:RegisterEffect(e1)
	--atk up/indestructable
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.tgtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetProperty(0)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(500)
	c:RegisterEffect(e3)
end
function s.lzcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.lzfilter(c)
	return c:GetSequence()>4
end
function s.lztg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(s.lzfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct end
	local dis=Duel.SelectDisableField(tp,ct,LOCATION_MZONE,LOCATION_MZONE,0)
	Duel.Hint(HINT_ZONE,tp,dis)
	e:SetLabel(dis)
end
function s.lzop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetOperation(s.disop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	e1:SetLabel(e:GetLabel())
	e:GetHandler():RegisterEffect(e1)
end
function s.disop(e,tp)
	return e:GetLabel()
end
function s.tgtg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end


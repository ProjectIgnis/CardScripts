--雲魔物－ニンバスマン
--Cloudian - Nimbusman
local s,id=GetID()
function s.initial_effect(c)
	--battle indestructable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--selfdes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(s.sdcon)
	c:RegisterEffect(e2)
	--summon proc
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SUMMON_PROC)
	e3:SetCondition(s.sumcon)
	e3:SetOperation(s.sumop)
	e3:SetValue(SUMMON_TYPE_TRIBUTE)
	c:RegisterEffect(e3)
	--tribute check
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(s.valcheck)
	c:RegisterEffect(e4)
	--add counter
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_COUNTER)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetCondition(s.addcon)
	e5:SetOperation(s.addc)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
	--atk
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_UPDATE_ATTACK)
	e6:SetValue(s.atkval)
	c:RegisterEffect(e6)
end
s.counter_place_list={0x1019}
function s.sdcon(e)
	return e:GetHandler():IsPosition(POS_FACEUP_DEFENSE)
end
function s.cfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and (c:IsControler(tp) or c:IsFaceup())
end
function s.sumcon(e,c,minc)
	if c==nil then return true end
	local min=1
	if minc>=1 then min=minc end
	local tp=c:GetControler()
	local mg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	return c:GetLevel()>4 and Duel.CheckTribute(c,min,10,mg)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp,c,minc)
	local min=1
	if minc>=1 then min=minc end
	local mg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	local sg=Duel.SelectTribute(tp,c,min,10,mg)
	c:SetMaterial(sg)
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	e:SetLabel(g:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_WATER))
end
function s.addcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_TRIBUTE)
end
function s.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(COUNTER_NEED_ENABLE+0x1019,e:GetLabelObject():GetLabel())
	end
end
function s.atkval(e,c)
	return Duel.GetCounter(0,1,1,0x1019)*500
end

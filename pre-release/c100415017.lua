--Evil★Twins キスキル・リィラ
--Evil★Twins Kisikil-Lilla
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Cannot be Special Summoned except by procedure
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--Special Summon by tributing 2 Link monsters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetRange(LOCATION_GRAVE)
	c:RegisterEffect(e3)
	--Make opponent send cards to GY
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.tgtg)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)
	--Gain ATK/DEF with Kiskil and Lilla in GY
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.atkcon)
	e5:SetValue(2200)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e6)
end
s.listed_series={0x24c,0x24d}
function s.rfilter(c,tp)
	return c:IsType(TYPE_LINK) and (c:IsControler(tp) or c:IsFaceup())
end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.CheckReleaseGroup(c:GetControler(),s.rfilter,2,false,2,true,c,c:GetControler(),nil,false,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Duel.SelectReleaseGroup(tp,s.rfilter,2,2,false,true,true,c,nil,nil,false,nil)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>2 end
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	local ct=#g-2
	if ct>0 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
		local sg=g:Select(1-tp,ct,ct,nil)
		Duel.SendtoGrave(sg,REASON_RULE)
	end
end
function s.atkcon(e)
	local g=Duel.GetFieldGroup(e:GetHandler():GetControler(),LOCATION_GRAVE,0)
	return g:IsExists(Card.IsSetCard,1,nil,0x24c) and g:IsExists(Card.IsSetCard,1,nil,0x24d)
end

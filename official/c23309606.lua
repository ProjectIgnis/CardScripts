--炎獄魔人ヘル・バーナー
--Infernal Incinerator
local s,id=GetID()
function s.initial_effect(c)
	--summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(s.otcon)
	e1:SetTarget(s.ottg)
	e1:SetOperation(s.otop)
	e1:SetValue(SUMMON_TYPE_TRIBUTE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_LIMIT_SET_PROC)
	c:RegisterEffect(e2)
	--atk
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(s.val)
	c:RegisterEffect(e3)
end
function s.otfilter(c,tp)
	return c:IsAttackAbove(2000) and (c:IsControler(tp) or c:IsFaceup())
end
function s.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	hg:RemoveCard(c)
	local mg=Duel.GetMatchingGroup(s.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	return #hg>0 and minc<=1 and Duel.CheckTribute(c,1,1,mg)
		and hg:FilterCount(Card.IsAbleToGraveAsCost,nil)==#hg
end
function s.ottg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local mg=Duel.GetMatchingGroup(s.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local sg=Duel.SelectTribute(tp,c,1,1,mg,nil,nil,true)
	if sg and #sg>0 then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	end
	return false
end
function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	if not sg then return end
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)-c
	Duel.SendtoGrave(hg,REASON_COST+REASON_DISCARD)
	c:SetMaterial(sg)
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
	sg:DeleteGroup()
end
function s.val(e,c)
	local tp=c:GetControler()
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)*-500+500+Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)*200
end

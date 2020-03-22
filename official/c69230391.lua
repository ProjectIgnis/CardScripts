--爆炎帝テスタロス
--Thestalos the Mega Monarch
local s,id=GetID()
function s.initial_effect(c)
	--summon with 1 tribute
	local e1=aux.AddNormalSummonProcedure(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0),s.otfilter)
	local e2=aux.AddNormalSetProcedure(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0),s.otfilter)
	--handes
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_HANDES+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(s.valcheck)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
function s.otfilter(c)
	return c:IsSummonType(SUMMON_TYPE_TRIBUTE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_TRIBUTE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
	if e:GetLabel()==1 then
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #g==0 then return end
	Duel.ConfirmCards(tp,g)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local hg=g:Select(tp,1,1,nil)
	Duel.SendtoGrave(hg,REASON_EFFECT+REASON_DISCARD)
	Duel.ShuffleHand(1-tp)
	local tc=hg:GetFirst()
	if tc:IsType(TYPE_MONSTER) then
		Duel.Damage(1-tp,tc:GetLevel()*200,REASON_EFFECT)
	end
	if e:GetLabel()==1 then
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_FIRE) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end

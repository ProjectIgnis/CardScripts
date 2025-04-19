--クリアー・ヴィシャス・ナイト
local s,id=GetID()
function s.initial_effect(c)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_REMOVE_ATTRIBUTE)
	e1:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e1)
	--summon with 1 tribute
	local e2=aux.AddNormalSummonProcedure(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0),nil,s.otop)
	local con=e2:GetCondition()
	e2:SetCondition(function(e,_c,...) if _c==nil then return true end return Duel.GetFieldGroupCount(_c:GetControler(),0,LOCATION_MZONE)>0 and con(e,_c,...) end)
	--atk
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.adcon)
	e3:SetValue(s.adval)
	c:RegisterEffect(e3)
end
function s.filter(c)
	return not c:IsStatus(STATUS_LEAVE_CONFIRMED)
end
function s.adcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.filter,e:GetHandler():GetControler(),LOCATION_ONFIELD|LOCATION_HAND,0,1,e:GetHandler())
end
function s.adval(e,c)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandler():GetControler(),0,LOCATION_MZONE,e:GetHandler())
	if #g==0 then 
		return 0
	else
		local tg,val=g:GetMaxGroup(Card.GetBaseAttack)
		return val
	end
end
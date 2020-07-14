--竜儀巧－メテオニス=DRA
--Draitron Meteornis=DRA
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Check material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)
	--Cannot be target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.tgval)
	c:RegisterEffect(e1)
	--Attack all
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetCondition(s.atkcon)
	e2:SetValue(s.atkfilter)
	c:RegisterEffect(e2)
	--Send targets to grave
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.gycon)
	e3:SetTarget(s.gytg)
	e3:SetOperation(s.gyop)
	c:RegisterEffect(e3)
end
s.listed_cards={100425032}
function s.tgval(e,re,rp)
	return aux.tgoval(e,re,rp) and re:IsActiveType(TYPE_MONSTER)
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:GetSum(Card.GetOriginalLevel)<=2 then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~(RESET_TOFIELD|RESET_LEAVE|RESET_TEMP_REMOVE),0,1)
	end
end
function s.atkcon(e)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_RITUAL) and c:GetFlagEffect(id)~=0
end
function s.atkfilter(e,c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp)
end
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and c:GetAttack()>0 and aux.SpElimFilter(c,true)
end
function s.rescon(sg,e,tp,mg)
	local atk=sg:GetSum(Card.GetAttack)
	return (atk==2000 or atk==4000),atk>4000
end
function s.tgfilter(c)
	return c:IsFaceup() and c:IsAbleToGrave()
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.tgfilter() end
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	local ct=Duel.GetMatchingGroupCount(aux.AND(s.tgfilter,Card.IsCanBeEffectTarget),tp,0,LOCATION_ONFIELD,nil,e)
	if chk==0 then return ct>0 and aux.SelectUnselectGroup(g,e,tp,1,#g,s.rescon,0) end
	local rg=aux.SelectUnselectGroup(g,e,tp,1,#g,s.rescon,1,tp,HINTMSG_REMOVE,s.rescon,nil,false)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	local gyc=Duel.GetOperatedGroup():GetSum(Card.GetAttack)//2000
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_ONFIELD,gyc,gyc,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,sg,#sg,0,0)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

--オッドアイズ・ネットワーク・ドラゴン
--Odd-Eyes Network Dragon
--Created and scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.matfilter,2)
	--boost
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_PENDULUM))
	e1:SetValue(s.bstval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--increase atk
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
function s.matfilter(c,lc,sumtype,tp)
	return (c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM,lc,sumtype,tp)) or c:IsSetCard(0x99) or c:IsSetCard(0x9f)
end
function s.bstval(e,c)
	return e:GetHandler():GetLinkedGroupCount()*300
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local lg=c:GetLinkedGroup()
		local a=Duel.GetAttacker()
		local d=a:GetBattleTarget()
		return c:GetFlagEffect(id)==0 and d
			and lg:IsContains(a) and lg:IsContains(d)
			and lg:IsExists(aux.nzatk,1,Group.FromCards(a,d))
	end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local a=Duel.GetAttacker()
	local d=a:GetBattleTarget()
	if not a:IsRelateToBattle() then return end
	if not d or not d:IsRelateToBattle() then return end
	if not a:IsControler(tp) then a,d=d,a end
	local lg=c:GetLinkedGroup()
	local ag=lg:Filter(aux.nzatk,Group.FromCards(a,d))
	if ag:GetCount()==0 then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(ag:GetSum(Card.GetAttack))
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	a:RegisterEffect(e1)
end

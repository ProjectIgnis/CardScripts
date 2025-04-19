--ＳＡＩＮＴ ＤＲＡＧＯＮ － ＴＨＥ ＧＯＤ ＯＦ ＯＳＩＲＩＳ
--マイケル・ローレンス・ディーによってスクリプト
--Scripted by MLD, credit to TPD & Cybercatman
--Updated and currently maintained by Larry126
Duel.EnableUnofficialProc(PROC_DIVINE_HIERARCHY)
local s,id=GetID()
function s.initial_effect(c)
	--X000
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(id)
	c:RegisterEffect(e0)
	--Summon with 3 Tribute
	local e1=aux.AddNormalSummonProcedure(c,true,false,3,3)
	local e2=aux.AddNormalSetProcedure(c,true,false,3,3)
	--Race "Dragon"
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_ADD_RACE)
	e3:SetValue(RACE_DRAGON)
	c:RegisterEffect(e3)
	--atk/def
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_SET_BASE_ATTACK)
	e4:SetCondition(function(e) return e:GetHandler():IsHasEffect(id) end)
	e4:SetValue(s.adval)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e5)
	--atkdown
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_DESTROY)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EVENT_SUMMON_SUCCESS)
	e6:SetCondition(s.atkcon)
	e6:SetTarget(s.atktg)
	e6:SetOperation(s.atkop)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e7)
	local e8=e6:Clone()
	e8:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e8)
end
function s.adval(e,c)
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)*1000
end
-------------------------------------------------------------------
function s.atkfilter(c,p)
	return c:IsControler(p) and c:IsPosition(POS_FACEUP)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsExists(s.atkfilter,1,nil,1-tp)
		and (not c:IsHasEffect(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		and not c:IsHasEffect(EFFECT_FORBIDDEN) and not c:IsHasEffect(EFFECT_CANNOT_ATTACK)
		and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_ATTACK_ANNOUNCE)
		and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_ATTACK)
		or c:IsHasEffect(EFFECT_UNSTOPPABLE_ATTACK))
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
	Duel.SetTargetCard(eg)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e):Filter(Card.IsFaceup,nil)
	if #g==0 then return end
	local dg=Group.CreateGroup()
	local c=e:GetHandler()
	for tc in aux.Next(g) do
		if tc:IsPosition(POS_FACEUP_ATTACK) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-2000)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
			if tc:GetAttack()==0 then dg:AddCard(tc) end
		elseif tc:IsPosition(POS_FACEUP_DEFENSE) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_DEFENSE)
			e1:SetValue(-2000)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
			if tc:GetDefense()==0 then dg:AddCard(tc) end
		end
	end
	if #dg==0 then return end
	Duel.BreakEffect()
	Duel.Destroy(dg,REASON_EFFECT)
end
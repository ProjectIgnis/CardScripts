--Ｅｍトラピーズ・フォーズ・ウィッチ
--Performage Trapeze Witch
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusiom Materials: 2 "Performage" monsters
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_PERFORMAGE),2)
	--Your "Performage" monsters cannot be targted by opponent's card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_PERFORMAGE))
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--Your "Performage" monsters cannot be destroyed by your card effects
	local e2=e1:Clone()
	e2:SetProperty(0)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(aux.indsval)
	c:RegisterEffect(e2)
	--Your opponent's monsters cannot target this card for attacks while you control another "Performage" monster
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.cannotatkcon)
	e3:SetValue(aux.imval2)
	c:RegisterEffect(e3)
	--Decrease the ATK of an opponent's monster by 600
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.atktg)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
s.listed_names={id}
s.listed_series={SET_PERFORMAGE}
function s.cannotatkfilter(c)
	return c:IsSetCard(SET_PERFORMAGE) and c:IsFaceup() and not c:IsCode(id)
end
function s.cannotatkcon(e)
	return Duel.IsExistingMatchingCard(s.cannotatkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc0,bc1=Duel.GetBattleMonster(tp)
	if chk==0 then return bc0 and bc1 and bc0:IsFaceup() and bc1:IsFaceup() and bc0:IsSetCard(SET_PERFORMAGE) end
	e:SetLabelObject(bc1)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,bc1,1,tp,-600)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc and tc:IsRelateToBattle() and tc:IsFaceup() and tc:IsControler(1-tp) then
		--That opponent's monster loses 600 ATK
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-600)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
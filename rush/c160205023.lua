--サイバー・ステルス・ドラゴン
--Cyber Stealth Dragon
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Summon with 1 tribute
	local e1=aux.AddNormalSummonProcedure(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0),s.otfilter)
	--atkup
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.con)
	e2:SetValue(2000)
	c:RegisterEffect(e2)
	--Cannot be destroyed
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.con)
	e3:SetValue(s.indval)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_CYBER_DRAGON}
function s.otfilter(c)
	return c:IsCode(CARD_CYBER_DRAGON) and c:IsFaceup()
end
function s.con(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,CARD_CYBER_DRAGON)
end
function s.indval(e,re,rp)
	local rc=re:GetHandler()
	return rc:IsMonster() and aux.indoval(e,re,rp)
end
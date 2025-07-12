--ＦＮｏ．０ 未来皇ホープ－フューチャー・スラッシュ
--Number F0: Utopic Future Slash
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Xyz Monsters with the same Rank, except "Number" monsters OR 1 "Utopia" monster or "Number F0: Utopic Future" you control
	Xyz.AddProcedure(c,s.xyzfilter,nil,2,s.ovfilter,aux.Stringid(id,0),nil,nil,false,s.xyzcheck)
	--Gains 500 ATK for each "Number" Xyz Monster in the GYs
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,c) return Duel.GetMatchingGroupCount(function(c) return c:IsSetCard(SET_NUMBER) and c:IsType(TYPE_XYZ) end,0,LOCATION_GRAVE,LOCATION_GRAVE,nil)*500 end)
	c:RegisterEffect(e1)
	--Cannot be destroyed by battle
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Make this card able to make a second attack during each Battle Phase this turn
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(function() return Duel.IsAbleToEnterBP() end)
	e3:SetCost(Cost.Detach(1))
	e3:SetTarget(s.secondatktg)
	e3:SetOperation(s.secondatkop)
	c:RegisterEffect(e3)
end
s.xyz_number=0
s.listed_series={SET_NUMBER,SET_UTOPIA}
s.listed_names={65305468} --"Number F0: Utopic Future"
function s.xyzfilter(c,xyz,sumtype,tp)
	return c:IsType(TYPE_XYZ,xyz,sumtype,tp) and not c:IsSetCard(SET_NUMBER,xyz,sumtype,tp)
end
function s.xyzcheck(g,tp,xyz)
	local mg=g:Filter(function(c) return not c:IsHasEffect(EFFECT_EQUIP_SPELL_XYZ_MAT) end,nil)
	return mg:GetClassCount(Card.GetRank)==1
end
function s.ovfilter(c,tp,xyzc)
	return (c:IsSetCard(SET_UTOPIA,xyzc,SUMMON_TYPE_XYZ,tp) or c:IsSummonCode(xyzc,SUMMON_TYPE_XYZ,tp,65305468)) and c:IsFaceup()
end
function s.secondatktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		return c:CanAttack() and c:GetEffectCount(EFFECT_EXTRA_ATTACK)==0
	end
end
function s.secondatkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		--This card can make a second attack during each Battle Phase this turn
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3201)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
	end
end

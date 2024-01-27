--ドローン・フォース・フュージョン
--Drone Force Fusion
--scripted by Larry126
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon 1 Fusion monster, using monsters from your field, including a "Drone" monster
	local e1=Fusion.CreateSummonEff(c,nil,Fusion.OnFieldMat,s.extrafil,s.extraop)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	c:RegisterEffect(e1)
end
s.listed_series={0x581}
function s.extrafil()
	return nil,s.matcheck
end
function s.matcheck(tp,sg,fc)
	return sg:IsExists(Card.IsDrone,1,nil,fc,SUMMON_TYPE_FUSION,tp)
end
function s.extraop(e,tc,tp,mat1)
	local e1=Effect.CreateEffect(tc)
	e1:SetDescription(aux.Stringid(68473226,0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD&-RESET_TOFIELD)
	tc:RegisterEffect(e1,true)
	if not tc:IsType(TYPE_EFFECT) then
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD&-RESET_TOFIELD)
		tc:RegisterEffect(e2,true)
	end
end

--ＳＮｏ．０ ホープ・ゼアル (Manga)
--Number S0: Utopic ZEXAL (Manga)
--Scripted by Larry126
Duel.LoadCardScript("c52653092.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,s.xyzfilter,nil,3)
	--This card's Special Summon cannot be prevented or negated
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(id)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	c:RegisterEffect(e2)
	--When Special Summoned, your opponent's cards and effects cannot be activated
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(function() Duel.SetChainLimitTillChainEnd(function(e,ep,tp) return tp==ep end) end)
	c:RegisterEffect(e3)
	--ATK/DEF
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SET_ATTACK)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(function(e) return e:GetHandler():HasFlagEffect(id+1) end)
	e4:SetValue(function(e,c) return c:GetFlagEffectLabel(id+1)*500 end)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e5)
	--Cannot be destroyed by battle except with "Number" monsters
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e6:SetValue(aux.NOT(aux.TargetBoolFunction(Card.IsSetCard,SET_NUMBER)))
	c:RegisterEffect(e6)
	aux.GlobalCheck(s,function()
		local oldf=Duel.Overlay
		Duel.Overlay=function(c,g,grave)
			if type(g)=="Card" then
				g=Group.FromCards(g)
			end
			local mg=g:Clone()
			if not grave then g:ForEach(function(gc) mg:Merge(gc:GetOverlayGroup()) end) end
			local rank=mg:GetSum(Card.GetRank)
			local label=c:GetFlagEffectLabel(id+1)
			if not label then
				c:RegisterFlagEffect(id+1,RESET_EVENT|RESETS_STANDARD&~RESET_TOFIELD,0,1,rank)
			else
				c:SetFlagEffectLabel(id+1,label+rank)
			end
			return oldf(c,g,grave)
		end
		local oldcf=Card.RegisterEffect
		Card.RegisterEffect=function(c,e,...)
			if e:GetCode()==EFFECT_CANNOT_SPECIAL_SUMMON then
				local oldTg=e:GetTarget()
				e:SetTarget(s.splimit(oldTg))
			end
			return oldcf(c,e,...)
		end
		local oldpf=Duel.RegisterEffect
		Duel.RegisterEffect=function(e,p)
			if e:GetCode()==EFFECT_CANNOT_SPECIAL_SUMMON then
				local oldTg=e:GetTarget()
				e:SetTarget(s.splimit(oldTg))
			end
			return oldpf(e,p)
		end
	end)
end
s.xyz_number=0
s.listed_series={SET_NUMBER,SET_NUMBER_S}
function s.splimit(target)
	return function (e,c,...)
		return not c:IsHasEffect(id) and (not target or target(e,c,...))
	end
end
function s.xyzfilter(c,xyz,sumtype,tp)
	return c:IsType(TYPE_XYZ,xyz,sumtype,tp) and c:IsSetCard(SET_NUMBER_S,xyz,sumtype,tp)
end
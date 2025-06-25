--剣聖の影霊衣－セフィラセイバー
--Zefrasaber, Swordmaster of the Nekroz
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--You cannot Pendulum Summon monsters, except "Nekroz" and "Zefra" monsters, this effect cannot be negated
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetRange(LOCATION_PZONE)
	e0:SetTargetRange(1,0)
	e0:SetTarget(function(e,c,sump,sumtype,sumpos,targetp) return (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM and not c:IsSetCard({SET_NEKROZ,SET_ZEFRA}) end)
	c:RegisterEffect(e0)
	local ritual_target_params={handler=c,lvtype=RITPROC_EQUAL,filter=function(ritual_c) return ritual_c:IsSetCard(SET_NEKROZ) and ritual_c~=c end,forcedselection=s.forcedselection}
	local ritual_operation_params={handler=c,lvtype=RITPROC_EQUAL,filter=function(ritual_c) return ritual_c:IsSetCard(SET_NEKROZ) end}
	--Tribute monsters from your hand or field, then Ritual Summon 1 "Nekroz" Ritual Monster from your hand whose Level exactly equals the total Levels of those monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND|LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.SelfTribute)
	e1:SetTarget(Ritual.Target(ritual_target_params))
	e1:SetOperation(Ritual.Operation(ritual_operation_params))
	c:RegisterEffect(e1)
end
s.listed_series={SET_NEKROZ,SET_ZEFRA}
function s.forcedselection(e,tp,g,sc)
	local c=e:GetHandler()
	return not g:IsContains(c),g:IsContains(c)
end